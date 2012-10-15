namespace MvcApplication130.Core.Interfaces.Data
{
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Objects;

    using MvcApplication130.Core.Model;

    public interface IDataContext
    {
        ObjectContext ObjectContext();
        IDbSet<T> DbSet<T>() where T : DomainObject;
        DbEntityEntry Entry<T>(T entity) where T : DomainObject;
        void Dispose();
    }
}