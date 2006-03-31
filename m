From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 02:45:44 -0800 (PST)
Message-ID: <20060331.024544.96296223.davem@davemloft.net>
References: <20060331.011245.26474207.davem@davemloft.net>
	<442D0186.8090705@kernelpanic.ru>
	<20060331103956.GA12181@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bb@kernelpanic.ru, jesse.brandeburg@intel.com,
	nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, ak@suse.de, jgarzik@pobox.com
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: herbert@gondor.apana.org.au
In-Reply-To: <20060331103956.GA12181@gondor.apana.org.au>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 31 Mar 2006 21:39:56 +1100

> Anyway, it didn't take long to find another bug in the same area.
> I'm afraid this driver does seem to be full of them :)

Indeed.

Thanks for picking through this some more Herbert.  I hope we got it
this time.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
