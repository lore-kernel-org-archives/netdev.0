From: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 15:02:33 +0400
Message-ID: <442D0C49.6070200@kernelpanic.ru>
References: <E1FPHFJ-0003Fq-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jesse.brandeburg@intel.com,
	nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, ak@suse.de, jgarzik@pobox.com
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FPHFJ-0003Fq-00@gondolin.me.apana.org.au>
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

Hello, Herbert Xu.

On 31.03.2006 14:52 you said the following:

> BTW, if you kept the built tree it is possible to apply the patch and
> then do a make which should compile just the e1000 driver.
> 
> Cheers,

Thank's for the tip, actually I knew that :) First of, I've already 
applied some other new patches from bk-commits-head. Not for the e1000 
driver. And second - I didn't keep the tree, rpmbuild cleaned it up :) 
That's why I'm recompiling entire kernel.

-- 
Boris B. Zhmurov
mailto: bb@kernelpanic.ru
"wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
