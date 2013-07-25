From: tedheadster <tedheadster@gmail.com>
Subject: Re: [PATCH] Change request_irq() to use struct net_device *dev->name
Date: Thu, 25 Jul 2013 11:20:24 -0400
Message-ID: <CAP8WD_aKqqB4Fb4Vadj_AJ4ET5gxd+EkaCMMVvBxxqNwDjpBGg@mail.gmail.com>
References: <1374646199-9398-1-git-send-email-pshah.mumbai@gmail.com>
	<51F07489.7010404@gmail.com>
	<CAD6i1fJO3geZ0vkHLsJEd+KedHkpC1OZVTJJskU2RAAKYBhhJQ@mail.gmail.com>
	<CAD6i1f+NYu7rcQwF-TXk4+OdjPNZwMKxxjJ9YA_+v9B6uPYq+g@mail.gmail.com>
	<CAHp75VdouA2w5WjBPJ2cX8AKvTeCNrj6pM+3SS5DzU+ARM5M3Q@mail.gmail.com>
Reply-To: whiteheadm@acm.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1997288843=="
Cc: kernel-mentors@selenic.com, Ryan Mallon <rmallon@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <kernel-mentors-bounces@selenic.com>
In-Reply-To: <CAHp75VdouA2w5WjBPJ2cX8AKvTeCNrj6pM+3SS5DzU+ARM5M3Q@mail.gmail.com>
List-Unsubscribe: <http://selenic.com/mailman/options/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

--===============1997288843==
Content-Type: multipart/alternative; boundary=089e0122e922b6237604e25790c4

--089e0122e922b6237604e25790c4
Content-Type: text/plain; charset=ISO-8859-1

Andy,
  I can't find a single example of a devres_* call in
drivers/net/ethernet/*. Does any networking code exist that we can look at
as an example for conversion to the devres API?

- Matthew

--089e0122e922b6237604e25790c4
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div>Andy,<br></div>=A0 I can&#39;t find a single exa=
mple of a devres_* call in drivers/net/ethernet/*. Does any networking code=
 exist that we can look at as an example for conversion to the devres API?<=
br>
<br></div>- Matthew<br><br></div>

--089e0122e922b6237604e25790c4--

--===============1997288843==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernel-mentors mailing list
Kernel-mentors@selenic.com
http://selenic.com/mailman/listinfo/kernel-mentors

--===============1997288843==--
