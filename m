From: Pedro Fortuna <pedro.fortuna@gmail.com>
Subject: Re: filtering packtes before OS takes care about them
Date: Sat, 5 Mar 2005 19:36:38 +0000
Message-ID: <db95d40c050305113668c3ff07@mail.gmail.com>
References: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
	 <7bca1cb50502281209798e8a00@mail.gmail.com>
	 <db95d40c0503050608e1e98d9@mail.gmail.com>
	 <7bca1cb505030510586aeb96c1@mail.gmail.com>
Reply-To: Pedro Fortuna <pedro.fortuna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Asim Shankar <asimshankar@gmail.com>
In-Reply-To: <7bca1cb505030510586aeb96c1@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Asim,
I tried again but this time in Fedora Core 3 (kernel 2.6.10-1.760_FC3)
and it went flawlessly.
I have a look into your example and also into the Phrack article you
mentioned and now I'm ready to begin some tests towards what I want to
implement.

It's absolutly clear you can fetch (and modify) packets before they
are delivered to the TCP/IP stack with a custom packet_type function,
but is it also possible to intercept just before they are passed to
the network driver?

Thanks,
-Pedro Fortuna


On Sat, 5 Mar 2005 12:58:23 -0600, Asim Shankar <asimshankar@gmail.com> wrote:
> > I wasnt able to compile your packet_type_test.c :
> > all I got was a huge list of errors
> > and warnings, and no .o compiled in the end.
> 
> Can you send the specific errors you got?
> And is the kernel sources present in
> /lib/modules/`uname -r`/build?
> 
> Regards,
> 
> -- Asim
>
