From: Xander Huff <xander.huff@ni.com>
Subject: Re: [PATCH v2 2/2] fixup! net/macb: improved ethtool statistics support
Date: Thu, 15 Jan 2015 09:32:35 -0600
Message-ID: <54B7DD93.8000104@ni.com>
References: <20150114.165220.2282566005036464131.davem@davemloft.net> <1421274051-21588-1-git-send-email-xander.huff@ni.com> <1421274051-21588-2-git-send-email-xander.huff@ni.com> <54B797E5.6070503@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jaeden.amero@ni.com, rich.tollerton@ni.com,
	ben.shelton@ni.com, brad.mouring@ni.com,
	linux-kernel@vger.kernel.org, cyrille.pitchen@atmel.com
To: Nicolas Ferre <nicolas.ferre@atmel.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54B797E5.6070503@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/15/2015 4:35 AM, Nicolas Ferre wrote:
>>   #define GEM_OTX					0x0100 /* Octets transmitted */
> I see, it's modified hereafter! Why not integrate this part in previous
> patch?
>
>

I split these up the way I did by using the --fixup argument to allow the rebase 
--autosquash to work. I could instead have a series of fixup commits to fix each 
type of style issue and then also the functional issue if you'd prefer, but 
--autosquash will no longer work.
