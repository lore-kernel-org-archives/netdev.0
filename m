From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 17/38] net/islpci_dev: replace
 schedule_timeout() with msleep()
Date: Fri, 01 Oct 2004 00:15:21 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <415CD9D9.2000607@pobox.com>
References: <20040923221303.GB13244@us.ibm.com>
	<20040923221303.GB13244@us.ibm.com>
	<5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mcgrof@studorgs.rutgers.edu, hvr@gnu.org,
	kernel-janitors@lists.osdl.org,
	Nishanth Aravamudan <nacc@us.ibm.com>, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Margit Schubert-While <margitsw@t-online.de>
In-Reply-To: <5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://mcgrof.com/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

I would rather see an msleep implementation in 2.4.x...
