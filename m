From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
 when promiscuous mode
Date: Tue, 13 Nov 2007 04:32:58 -0800 (PST)
Message-ID: <20071113.043258.222942202.davem@davemloft.net>
References: <20071113120328.GB1086@gondor.apana.org.au>
	<20071113.040624.43544149.davem@davemloft.net>
	<20071113121647.GA1330@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, joonwpark81@gmail.com, w@1wt.eu,
	cfriesen@nortel.com, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20071113121647.GA1330@gondor.apana.org.au>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 13 Nov 2007 20:16:47 +0800

> Perhaps those who want to push this patch should be encouraged
> to convert e1000 to the new interface :)

That is my feeling as well :-)

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
