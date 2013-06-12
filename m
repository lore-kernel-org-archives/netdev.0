From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH] sockperf: add SO_LL socketop support
Date: Wed, 12 Jun 2013 11:45:21 +0300
Message-ID: <51B83521.8080201@linux.intel.com>
References: <20130611142415.17879.75569.stgit@ladj378.jer.intel.com>
	<51B73395.7070706@linux.intel.com> <51B83326.4080201@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Kehati <ork@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>, linux-kernel@vger.kernel.org,
	Avner Ben Hanoch <avnerb@mellanox.com>, Andi Kleen <andi@firstfloor.org>,
	Alex Rosenbaum <Alexr@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>,
	David Miller <davem@davemloft.net>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51B83326.4080201@mellanox.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/06/2013 11:36, Amir Vadai wrote:
> On 11/06/2013 17:26, Eliezer Tamir wrote:
>> Add lls socket option support to sockperf.
>> Right now we always get the option before set to show the option is
>> working properly. We should probably remove that in an official release.
>> use --lls (value in usecs) to override global setting.
>> ---

> Eliezer Hi,
>
> Added sockperf maintainers to CC list.

Thank you.

Please note that I plan on revising this patch, so don't add it just 
yet. (I will CC the maintainers on further versions.)

-Eliezer

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
