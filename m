From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/2] adding tracepoints to vhost
Date: Tue, 10 Apr 2012 16:45:22 +0300
Message-ID: <20120410134522.GC18899@redhat.com>
References: <20120410025327.49693.93562.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<CAJSP0QWA1z6_YQe9hhpG7bCyZQarmU5NXbHsLGTL_zPTk3dOUA@mail.gmail.com>
	<20120410124250.GB29808@redhat.com>
	<CAEH94Li0==w=AUKd5WCPMcqxLh=+N6bKttOwrE8y-xuOyPt_QA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CAEH94Li0==w=AUKd5WCPMcqxLh=+N6bKttOwrE8y-xuOyPt_QA@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 09:10:48PM +0800, Zhi Yong Wu wrote:
> >> Perhaps this can replace the vhost log feature? =A0I'm not sure if
> >> tracepoints support the right data types but it seems like vhost
> >> debugging could be done using tracing with less code.
> >>
> >> Stefan
> >
> > vhost log is not a debugging tool, it logs memory accesses for
> > migration.
> Great, it is very appreciated if there's some docs about this

About what? vhost logging? See the comment near the
definition of VHOST_SET_LOG_BASE in vhost.h

> > _______________________________________________
> > Virtualization mailing list
> > Virtualization@lists.linux-foundation.org
> > https://lists.linuxfoundation.org/mailman/listinfo/virtualization
> =

> =

> =

> -- =

> Regards,
> =

> Zhi Yong Wu
