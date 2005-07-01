From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] multipath routing algorithm, better patch
Date: Fri, 01 Jul 2005 21:34:18 +0200
Message-ID: <42C59ABA.1070305__18280.8403777473$1120246300$gmane$org@trash.net>
References: <Pine.GSO.4.61.0506302014160.7400@rac1.wam.umd.edu> <42C4919A.5000009@trash.net> <20050701174117.GW16076@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Patrick Jenkins <patjenk@wam.umd.edu>, linux-kernel@vger.kernel.org,
        Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050701174117.GW16076@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <42C4919A.5000009@trash.net> 2005-07-01 02:43
> 
>>If it isn't set correctly its an iproute problem. Did you actually
>>experience any problems?
> 
> Well, my patch for iproute2 to enable multipath algorithm selection
> is currently being merged to Stephen together with the ematch bits.
> We had to work out a dependency on GNU flex first (the berkley
> version uses the same executable names) so the inclusion was
> delayed a bit.

So its no problem but simply missing support. BTW, do you know if
Stephen's new CVS repository is exported somewhere?

Regards
Patrick
