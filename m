From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v2] ARC: axs10x - add Ethernet PHY description in .dts
Date: Thu, 17 Mar 2016 11:37:58 +0000
Message-ID: <1458214678.14496.15.camel@synopsys.com>
References: <1458207712-29435-1-git-send-email-abrodkin@synopsys.com>
	 <56EA8DCC.8070308@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-7"
Content-Transfer-Encoding: 8BIT
Cc: "robh@kernel.org" <robh@kernel.org>,
	"preid@electromag.com.au" <preid@electromag.com.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"linux-snps-arc@lists.infradead.org"
	<linux-snps-arc@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56EA8DCC.8070308@cogentembedded.com>
Content-Language: en-US
Content-ID: <9E74614347558B4E8E83D082031B8B98@internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Thu, 2016-03-17 at 13:58 +-0300, Sergei Shtylyov wrote:
+AD4- On 3/17/2016 12:41 PM, Alexey Brodkin wrote:
+AD4- 
+AD4- +AD4- 
+AD4- +AD4- Following commit broke DW GMAC functionality on AXS10x boards:
+AD4- +AD4- http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id+AD0-e34d65696d2ef13dc32f2a162556c86c461ed763
+AD4- +AKAAoACgAKA-Note that scripts/checkpatch.pl now enforces certain format for citing+AKA-
+AD4- commits: commit +ADw-12-digit SHA1+AD4- (+ACIAPA-commit summary+AD4AIg-).

Frankly I haven't run that patch through checkpatch due to patch
simplicity.

But I'll try to not do any assumptions from now on and will try to
use checkpatch for each and every thing I send :)

Thanks for spotting all his+ACE-

-Alexey
