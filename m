From: Andreas Jellinghaus <aj@ciphirelabs.com>
Subject: Re: [ACRYPTO] New asynchronous crypto layer (acrypto) release.
Date: Thu, 28 Sep 2006 15:23:43 +0200
Message-ID: <451BCCDF.5000201__22581.6741855398$1159451668$gmane$org@ciphirelabs.com>
References: <20060928120826.GA18063@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751906AbWI1Nvo@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <20060928120826.GA18063@2ka.mipt.ru>
Cc: linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Hello.
> 
> I'm pleased to announce asynchronous crypto layer (acrypto) [1] release 
> for 2.6.18 kernel tree. Acrypto allows to handle crypto requests 
> asynchronously in hardware.
> 
> Combined patchset includes:
>  * acrypto core
>  * IPsec ESP4 port to acrypto
>  * dm-crypt port to acrypto

so I should be able to replace a plain 2.6.18 kernel with one
with this patchset and use dm-crypt'ed partitions (e.g. swap,
encrypted root filesystem) as usual without further changes?

Did anyone test this with success?

Regards, Andreas
