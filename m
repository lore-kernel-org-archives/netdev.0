From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: linux-next: manual merge of the net tree with the  tree
Date: Tue, 12 Oct 2010 07:56:42 +0200
Message-ID: <4CB3F89A.2010005@s5r6.in-berlin.de>
References: <20101012111716.0c54b093.sfr@canb.auug.org.au>
	<20101012145135.9697fe21.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	linux1394-devel@lists.sourceforge.net, David Miller <davem@davemloft.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20101012145135.9697fe21.sfr@canb.auug.org.au>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Stephen Rothwell wrote:
> Hi all,
> 
> On Tue, 12 Oct 2010 11:17:16 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>> Today's linux-next merge of the net tree got a conflict in
>> drivers/ieee1394/eth1394.c between commit
>> 66fa12c571d35e3cd62574c65f1785a460105397 ("ieee1394: remove the old IEEE
>> 1394 driver stack") from the  tree and commit
>                                ^
> I meant to say "the ieee1394 tree".

(I should have put the ieee1394 removal into -next much earlier.  OTOH the
conflicting commit is from August 17 already...)

Would it be useful if I rebase this small ieee1394 removal branch of mine onto
net?
-- 
Stefan Richter
-=====-==-=- =-=- -==--
http://arcgraph.de/sr/

------------------------------------------------------------------------------
Beautiful is writing same markup. Internet Explorer 9 supports
standards for HTML5, CSS3, SVG 1.1,  ECMAScript5, and DOM L2 & L3.
Spend less time writing and  rewriting code and more time creating great
experiences on the web. Be a part of the beta today.
http://p.sf.net/sfu/beautyoftheweb
