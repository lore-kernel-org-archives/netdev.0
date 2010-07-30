From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: Re: e1000e crashes with 2.6.34.x and ThinkPad T60
Date: Fri, 30 Jul 2010 10:42:03 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A9001649C4653@orsmsx509.amr.corp.intel.com>
References: <20100724092644.GA13353@torres.zugschlus.de>
	<8DD2590731AB5D4C9DBF71A877482A9001623EC48E@orsmsx509.amr.corp.intel.com>
	<20100730125614.GB21444@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>, Linux
To: Marc Haber <mh+linux-kernel@zugschlus.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100730125614.GB21444@torres.zugschlus.de>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Friday, July 30, 2010 5:56 AM, Marc Haber wrote:
> On Mon, Jul 26, 2010 at 09:13:45AM -0700, Allan, Bruce W wrote:
>> Adding e1000-devel (the Intel LAN developers list).
>> 
>> Please supply the full dmesg you meant to attach with the original
>> report, as well as the output of lspci -vvv.
> 
> Stupid me.
> 
> Greetings
> Marc

Please also provide an eeprom dump from the wired LOM via 'ethtool -e ethX'.

Thanks,
Bruce.
------------------------------------------------------------------------------
The Palm PDK Hot Apps Program offers developers who use the
Plug-In Development Kit to bring their C/C++ apps to Palm for a share
of $1 Million in cash or HP Products. Visit us here for more details:
http://p.sf.net/sfu/dev2dev-palm
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
