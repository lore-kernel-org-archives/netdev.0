From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: ath9k gpio request
Date: Wed, 01 Jun 2016 16:42:49 +0530
Message-ID: <574EC331.1080901@gmail.com>
References: <20160530132225.4d297678@canb.auug.org.au>	<574C4851.9090201@gmail.com> <87fusy3cqx.fsf_-_@kamboji.qca.qualcomm.com>,<574D3EAA.3060102@gmail.com> <1464764036580.70506@qti.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	ath9k-devel <ath9k-devel@qualcomm.com>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Miaoqing Pan <miaoqing@codeaurora.org>
To: "Pan, Miaoqing" <miaoqing@qti.qualcomm.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464764036580.70506@qti.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 June 2016 12:24 PM, Pan, Miaoqing wrote:
> which chip ?  And what's the GPIO number ?

lspci -v reports:
09:00.0 Network controller: Qualcomm Atheros AR9462 Wireless Network 
Adapter (rev 01)
	Subsystem: Foxconn International, Inc. Device e052
	Flags: bus master, fast devsel, latency 0, IRQ 19
	Memory at c0500000 (64-bit, non-prefetchable) [size=512K]
	Expansion ROM at c0580000 [disabled] [size=64K]
	Capabilities: [40] Power Management version 2
	Capabilities: [50] MSI: Enable- Count=1/4 Maskable+ 64bit+
	Capabilities: [70] Express Endpoint, MSI 00
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
	Capabilities: [160] Device Serial Number 00-00-00-00-00-00-00-00
	Kernel driver in use: ath9k

Any easy way to find out the gpio number or i can modify the module to 
find that out.

Regards
Sudip
