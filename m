From: "David S. Miller" <davem@davemloft.net>
Subject: [KJ] Re: [PATCH 21/39] net/ipconfig: replace schedule_timeout() with
 msleep()
Date: Tue, 8 Feb 2005 20:37:02 -0800
Message-ID: <20050208203702.7f033fcb.davem@davemloft.net>
References: <20050120235749.GJ2600@us.ibm.com>
	<Xine.LNX.4.44.0501202135280.4666-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============39266409317648598=="
Cc: netdev@oss.sgi.com, kaber@coreworks.de, yoshfuji@linux-ipv6.org,
   kernel-janitors@lists.osdl.org, kuznet@ms2.inr.ac.ru
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0501202135280.4666-100000@thoron.boston.redhat.com>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============39266409317648598==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Thu, 20 Jan 2005 21:36:42 -0500 (EST)
James Morris <jmorris@redhat.com> wrote:

> On Thu, 20 Jan 2005, Nishanth Aravamudan wrote:
> 
> > Hi,
> > 
> > Please consider applying.
> > 
> > Description: Use msleep() instead of schedule_timeout() to guarantee the task
> > delays as expected. Change the units of the two constants to be msecs and secs
> > respectively.
> 
> Looks fine to me.

To me too, applied.  Thanks Nishanth.

--===============39266409317648598==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============39266409317648598==--
