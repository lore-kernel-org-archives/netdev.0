From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH v2 2/2 ] net: ethernet: nb8800: handle all RGMII
 definitions
Date: Fri, 4 Nov 2016 19:24:39 +0100
Message-ID: <581CD267.5060800@laposte.net>
References: <581CA3D0.6080808@laposte.net>
 <8c491fff-4849-fa9b-0a0a-5a7a6870120d@gmail.com>
 <581CBF17.2010108@laposte.net>
 <20161104.135448.1013810503648782291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, mans@mansr.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, slash.tmp@free.fr, andrew@lunn.ch
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104.135448.1013810503648782291.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 11/04/2016 06:54 PM, David Miller wrote:
> From: Sebastian Frias <sf84@laposte.net>
> Date: Fri, 4 Nov 2016 18:02:15 +0100
> 
>> Commit a999589ccaae ("phylib: add RGMII-ID interface mode definition")
>> and commit 7d400a4c5897 ("phylib: add PHY interface modes for internal
>> delay for tx and rx only") added several RGMII definitions:
>> PHY_INTERFACE_MODE_RGMII_ID, PHY_INTERFACE_MODE_RGMII_RXID and
>> PHY_INTERFACE_MODE_RGMII_TXID to deal with internal delays.
>>
>> Those are all RGMII modes (1Gbit) and must be considered that way when
>> setting the MAC mode or the pad mode for the HW to work properly.
>>
>> Signed-off-by: Sebastian Frias <sf84@laposte.net>
> 
> You cannot just repost one part of a patch series when you make changes.
> 
> You must always repost the entire series as a new fresh version, with
> changelog entries added to your "[PATCH v2 0/2] ..." header posting.
> 

Thanks for the information.

I sent v2, and then v3, because v2 had formatting issues, hopefully it is
ok now.

Best regards,

Sebastian
