From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Reproducible panics with tulip
Date: Sat, 19 Mar 2005 11:20:53 +0100
Message-ID: <20050319102053.GA1704@electric-eye.fr.zoreil.com>
References: <1111178167.1147.9.camel@localhost.localdomain> <20050318215229.GA24509@electric-eye.fr.zoreil.com> <20050318223939.GB24509@electric-eye.fr.zoreil.com> <1111224092.964.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
To: Alexander Nyberg <alexn@dsv.su.se>
Content-Disposition: inline
In-Reply-To: <1111224092.964.2.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alexander Nyberg <alexn@dsv.su.se> :
[...]
> I guess it was unclear in the output mess, the real problem at the
> bottom was:

No, no, not at all. It is clear but I'd prefer to see the same oops
without the netconsole parameter into play. A pure nfs + driver + race
oops will be fun enough for me. :o)

--
Ueimor
