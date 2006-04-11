From: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Subject: Re: [PATCH] IrDA: smcinit merged into smsc-ircc driver
Date: Tue, 11 Apr 2006 09:53:15 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0604110952590.27520@math.ut.ee>
References: <20060411040958.5B27913D8B@rhn.tartu-labor>
 <Pine.GSO.4.60.0604110841130.6504@igloo.df.lth.se>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linus Walleij <triad-HEm3bjczhZmzQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <Pine.GSO.4.60.0604110841130.6504-fcPyB2Jy8d0vOS8lKHy7yQ@public.gmane.org>
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

>> Detected unconfigured Toshiba Satellite 1800 SMSC IrDA chip, 
>> pre-configuring device.
>> SORRY: Toshiba Satellite 1800 has an unsupported bridge controller (ALi): 
>> not pre-configured.
>> smsc-ircc2, Preconfiguration failed !
>
> Yep we don't have support for ALi bridges yet, the Toshiba 1800 still needs 
> tosh1800 smcinit. But if you're willing to test, I can make a try to create a 
> 1800-compliant ALi initializer implementation out of the blue...

I am willing to test patches.

-- 
Meelis Roos (mroos-Y27EyoLml9s@public.gmane.org)


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
