From: James Morris <jmorris@redhat.com>
Subject: [KJ] Re: [PATCH 21/39] net/ipconfig: replace schedule_timeout() with
 msleep()
Date: Thu, 20 Jan 2005 21:36:42 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0501202135280.4666-100000@thoron.boston.redhat.com>
References: <20050120235749.GJ2600@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============92462092264671125=="
Cc: netdev@oss.sgi.com, kernel-janitors@lists.osdl.org,
   yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, kaber@coreworks.de,
   davem@davemloft.net
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: <20050120235749.GJ2600@us.ibm.com>
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

--===============92462092264671125==
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Thu, 20 Jan 2005, Nishanth Aravamudan wrote:

> Hi,
> 
> Please consider applying.
> 
> Description: Use msleep() instead of schedule_timeout() to guarantee the task
> delays as expected. Change the units of the two constants to be msecs and secs
> respectively.

Looks fine to me.


- James
-- 
James Morris
<jmorris@redhat.com>



--===============92462092264671125==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============92462092264671125==--
