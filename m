From: "Krishnakumar. R" <krishnakumar@naturesoft.net>
Subject: Re: Regarding 8139 physical identification
Date: Sun, 22 Feb 2004 15:42:50 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402221542.50052.krishnakumar@naturesoft.net>
References: <200402221532.48173.krishnakumar@naturesoft.net>
Reply-To: krishnakumar@naturesoft.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200402221532.48173.krishnakumar@naturesoft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

> Dear Becker,

Sorry for the typo... Please read it as "Hi List"....
But contents are same as I wanted to ask....


>
> I was trying to implement the physical identification
> for the 8139 series cards.
> For this I need to light the led of the card,
> when I need for the purpose of physically identifying it.
>
> After going through the manual, archives
> and writing some code, I have found that
> the lights of the led cannot be lighted by
> writing values to the "Config1" register's led bits.
> Neither does manipulating the values in the
> "CS" registers results in any led being lit.
>
> What is the way to light the led manually.
> I understand that according to the configurations
> set the led will light in case of the link, tx, rx etc.
> But I want to light the led explicitly.
> Is there a way to do it ?
>
> Regards,
> KK.

-- 
HomePage: http://puggy.symonds.net/~krishnakumar
