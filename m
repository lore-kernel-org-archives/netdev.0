From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] [TRY2] Use nfmark as a key in u32 classifier
Date: Tue, 9 Nov 2004 15:00:30 +0200 (EET)
Message-ID: <Pine.LNX.4.61.0411091458010.20094@webhosting.rdsbv.ro>
References: <Pine.LNX.4.61.0411091406570.20094@webhosting.rdsbv.ro>
 <1100003794.1114.61.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: davem@davemloft.net, linux-net@vger.kernel.org,
	lartc@mailman.ds9a.nl, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1100003794.1114.61.camel@jzny.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 9 Nov 2004, jamal wrote:

>
> Looks quiet palatable. You didnt CC Dave for inclusion

Yes, I tought that he reads evry message on netdev...
I added him, thanks.

Dave, please, include it in next release.
Thank you.

>
> cheers,
> jamal
>
> On Tue, 2004-11-09 at 07:27, Catalin(ux aka Dino) BOIE wrote:
>> Hello!
>>
>> This is the try number two.
>> What was changed:
>> - Added selectable choice in Kconfig file (thanks Jamal!)
>> - Don't abuse tc_u32_sel to not break backward compatibility (thanks
>> Patrick!).
>>
>> Stephen, do you have any comments on iproute2 part? I know it's not
>> perfect but this is the best way, I think. "u32 match mark vvvv mmmm" it's
>> intuitive but breaks a little the levels, "u32 mark vvvv mmmm" it's ok
>> but not intuitive....
>> If you want I can rewrite it if you want.
>>
>> Thank you for your time.
>>
>> Signed-off-by: Catalin(ux aka Dino) <catab at umbrella.ro>
>>
>> ---
>> Catalin(ux aka Dino) BOIE
>> catab at deuroconsult.ro
>> http://kernel.umbrella.ro/
>

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
