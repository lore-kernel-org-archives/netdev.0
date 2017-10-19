From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH v2 net-next 1/2] net: dsa: lan9303: Add port_fast_age and
 port_fdb_dump methods
Date: Thu, 19 Oct 2017 17:19:07 +0200
Message-ID: <e5987e93-e538-3382-455b-89e84083e169@egil-hjelmeland.no>
References: <20171019121015.7395-1-privat@egil-hjelmeland.no>
 <20171019121015.7395-2-privat@egil-hjelmeland.no>
 <87mv4nw869.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <1976baec-5ec3-9ec4-252b-743d9f1d9579@egil-hjelmeland.no>
 <871slzmars.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <871slzmars.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19. okt. 2017 17:12, Vivien Didelot wrote:
> Hi Egil,
> 
> Egil Hjelmeland <privat@egil-hjelmeland.no> writes:
> 
>>> Why is there different spacing and prefix with these defines?
>>
>> The extra space is to set bit definitions apart from register offsets,
>> a convention that is used in the file. However, agree that the
>> bit defs should be prefixed with LAN9303_ to be consistent with
>> rest of the file.
> 
> OK, I'm fine with this spacing then. The prefix would be nice though,
> thanks!
> 
Prefix already done in my working version.

> 
> If you cannot think about a comment text which brings value, it
> certainly means it isn't necessary. As you said the implicit "alr"
> namespace already helps here. I'd personally drop all section comments
> ;-)
> 

Then I will just drop the section comments.

> 
> Thank you,
> 
>        Vivien
> 

Egil
