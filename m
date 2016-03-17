From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH v2] ARC: axs10x - add Ethernet PHY description in .dts
Date: Thu, 17 Mar 2016 12:16:15 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075F4E90440@us01wembx1.internal.synopsys.com>
References: <1458207712-29435-1-git-send-email-abrodkin@synopsys.com>
 <56EA8DCC.8070308@cogentembedded.com>
 <1458214678.14496.15.camel@synopsys.com>
 <C2D7FE5348E1B147BCA15975FBA23075F4E903EF@us01wembx1.internal.synopsys.com>
 <56EA9C0D.1090000@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "robh@kernel.org" <robh@kernel.org>,
	"preid@electromag.com.au" <preid@electromag.com.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"linux-snps-arc@lists.infradead.org"
	<linux-snps-arc@lists.infradead.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 17 March 2016 05:29 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 3/17/2016 2:41 PM, Vineet Gupta wrote:
>
>>>>> >>>> Following commit broke DW GMAC functionality on AXS10x boards:
>>>>> >>>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=e34d65696d2ef13dc32f2a162556c86c461ed763
>>>> >>>      Note that scripts/checkpatch.pl now enforces certain format for citing
>>>> >>> commits: commit <12-digit SHA1> ("<commit summary>").
>>> >> Frankly I haven't run that patch through checkpatch due to patch
>>> >> simplicity.
>>> >>
>>> >> But I'll try to not do any assumptions from now on and will try to
>>> >> use checkpatch for each and every thing I send :)
>>> >>
>>> >> Thanks for spotting all his!
>>> >>
>     Sorry for not reporting everything on the 1st review.
>
>>> >> -Alexey
>> >
>> > Sergei, do you mind providing a Ack/Reviewed-by on the patch below
>  >
>
> Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Thx.

>     The patch here is white space damaged however: tabs were converted to 
> spaces. :-(
>
> MBR, Sergei


That was just because of copy-paste into mailer before switching to plain-text.
Don't ask - corporate email !
I added it just to give u an idea of what fixup i did.

Tx,
-Vineet
