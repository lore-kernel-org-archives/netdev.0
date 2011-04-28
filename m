From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3 1/7] ethtool: cosmetics: enforce
 const-ness in ethtool_cmd_speed
Date: Thu, 28 Apr 2011 03:03:02 +0100
Message-ID: <1303956182.3032.422.camel@localhost>
References: <1303954043-17440-1-git-send-email-decot@google.com>
	<1303954043-17440-2-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: David Decotigny <decot@google.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1303954043-17440-2-git-send-email-decot@google.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2011-04-27 at 18:27 -0700, David Decotigny wrote:
> The 'ep' argument of ethtool_cmd_speed is not altered: advertise it in
> protoype. +Indentation fix. Also add comments to advise using the
> ethtool_cmd_speed API to get/set the link speed.
> 
> Signed-off-by: David Decotigny <decot@google.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
WhatsUp Gold - Download Free Network Management Software
The most intuitive, comprehensive, and cost-effective network 
management toolset available today.  Delivers lowest initial 
acquisition cost and overall TCO of any competing solution.
http://p.sf.net/sfu/whatsupgold-sd
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
