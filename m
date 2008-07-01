From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 01 Jul 2008 17:44:36 +0200
Message-ID: <486A50E4.7050000@trash.net>
References: <20080701113927.GA16343@2ka.mipt.ru> <486A1AC7.9020706@trash.net> <20080701120320.GA9412@2ka.mipt.ru> <486A2487.2010303@trash.net> <486A31FF.8050201@garzik.org> <486A3286.9060100@trash.net> <486A4E70.3000603@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <486A4E70.3000603@garzik.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Patrick McHardy wrote:
>> I for one would be much happier to only have netfilter as a user
>> of this :)
> 
> I'm not sure I understand?  When site A connects to site B via TCP, is 
> there a problem letting site A know the OS of site B?

No, I expressed myself very unclear, sorry :) I meant to say
that I would be happier to have netfilter as a user of some
generic infrastructure instead of having all of this implemented
as netfilter module.
