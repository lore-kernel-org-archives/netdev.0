From: Daniele Venzano <venza@brownhat.org>
Subject: Re: sis900 and fedora troubles
Date: Sun, 26 Jun 2005 13:30:35 +0200
Message-ID: <5FFAEBAA-3C89-4F61-AE59-2E8D7ED42933@brownhat.org>
References: <1119667765.8496.6.camel@localhost.localdomain> <20050626085050.GA22215@electric-eye.fr.zoreil.com>
Mime-Version: 1.0 (Apple Message framework v730)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Damian <res0d26i@verizon.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050626085050.GA22215@electric-eye.fr.zoreil.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Il giorno 26/giu/05, alle ore 10:50, Francois Romieu ha scritto:

> The exact revisions for both kernels are needed as a start. The  
> complete
> dmesg would be welcome as well (if it gets truncated, the missing bits
> are probably stored in some distro-specific localtion, see /var/log  
> for
> instance).
>
> So far it is not even clear if it should be bugzilled in Fedora or  
> in Ubuntu
> (anyway, if changes can not be tested due to the lack of  
> connection... :o/ ).

I asked Damian (but forgot to CC the list) to check the sis900 driver  
version strings printed by the two configurations. I fear that Fedora  
is still using an old version of sis900, as I remember to have fixed  
a similar issue on the same hardware.

--
Daniele Venzano
http://www.brownhat.org
