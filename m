From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [PATCH 2.6.9-rc2 17/38] net/islpci_dev: replace
 schedule_timeout() with msleep()
Date: Fri, 01 Oct 2004 09:04:27 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <5.1.0.14.2.20041001084419.02570b18@pop.t-online.de>
References: <5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
	<20040923221303.GB13244@us.ibm.com>
	<20040923221303.GB13244@us.ibm.com>
	<5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de> <415CD9D9.2000607@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: netdev@oss.sgi.com, mcgrof@studorgs.rutgers.edu, hvr@gnu.org,
	kernel-janitors@lists.osdl.org, nacc@us.ibm.com,
	prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <415CD9D9.2000607@pobox.com>
References: <5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
	<20040923221303.GB13244@us.ibm.com>
	<20040923221303.GB13244@us.ibm.com>
	<5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://mcgrof.com/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

At 00:15 01.10.2004 -0400, Jeff scribeth:
>I would rather see an msleep implementation in 2.4.x...

Hear, hear.
And can we PLEASE have a
"#define HAVE_MSLEEP"  in delay.h ?!!!
(2.4. AND 2.6)

Margit
