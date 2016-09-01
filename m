From: Lars-Peter Clausen <lars@metafoo.de>
Subject: Re: [Patch v3 07/11] MIPS: Xilfpga: Add DT node for AXI I2C
Date: Thu, 1 Sep 2016 12:57:15 +0200
Message-ID: <74279d97-beeb-e754-40ad-3bfc8eeba66d@metafoo.de>
References: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472661352-11983-8-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: soren.brinkmann@xilinx.com, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, michal.simek@xilinx.com,
        netdev@vger.kernel.org
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>,
        monstr@monstr.eu, ralf@linux-mips.org, tglx@linutronix.de,
        jason@lakedaemon.net, marc.zyngier@arm.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1472661352-11983-8-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 08/31/2016 06:35 PM, Zubair Lutfullah Kakakhel wrote:
[..]
> +	    ad7420@4B {
> +		compatible = "adt7420";

"adi,adt7420"

> +		reg = <0x4B>;
> +	    };
> +	} ;
>  };
