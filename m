From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][ATM]: [drivers] use msleep() instead of
 schedule_timeout() (from Nishanth Aravamudan <nacc@us.ibm.com>)
Date: Thu, 23 Sep 2004 13:30:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923133052.259d3e39.davem@davemloft.net>
References: <20040923160710.GB1699@us.ibm.com>
	<200409231626.i8NGQ44f014489@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nacc@us.ibm.com, netdev@oss.sgi.com, davem@redhat.com,
        kernel-janitors@lists.osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
In-Reply-To: <200409231626.i8NGQ44f014489@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2004 12:26:05 -0400
"chas williams (contractor)" <chas@cmf.nrl.navy.mil> wrote:

> # ChangeSet
> #   2004/09/23 12:24:28-04:00 chas@relax.cmf.nrl.navy.mil 
> #   [ATM]: [lanai] get sleep interval right

Applied, thanks.
