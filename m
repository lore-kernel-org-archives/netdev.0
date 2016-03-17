From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] ARC: axs10x - add Ethernet PHY description in .dts
Date: Thu, 17 Mar 2016 13:58:20 +0300
Message-ID: <56EA8DCC.8070308@cogentembedded.com>
References: <1458207712-29435-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh@kernel.org>, Phil Reid <preid@electromag.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@vger.kernel.org, #@synopsys.com, 4.5.x@synopsys.com
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	linux-snps-arc@lists.infradead.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1458207712-29435-1-git-send-email-abrodkin@synopsys.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/17/2016 12:41 PM, Alexey Brodkin wrote:

> Following commit broke DW GMAC functionality on AXS10x boards:
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=e34d65696d2ef13dc32f2a162556c86c461ed763

    Note that scripts/checkpatch.pl now enforces certain format for citing 
commits: commit <12-digit SHA1> ("<commit summary>").

[...]

MBR, Sergei
