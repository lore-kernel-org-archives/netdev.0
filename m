From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: disablenetwork() syscall?
Date: Sun, 13 Jul 2003 10:04:39 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307131003440.19847-100000@netcore.fi>
References: <Mutt.LNX.4.44.0307080954170.5824-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Mutt.LNX.4.44.0307080954170.5824-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

FWIW,

DJB created a (probably biased) web page:

 http://cr.yp.to/unix/disablenetwork.html

to describe the idea and alternatives at a bit more length.

On Tue, 8 Jul 2003, James Morris wrote:

> On Mon, 7 Jul 2003, Pekka Savola wrote:
> 
> > Hi,
> > 
> > In a bugtraq thread, DJ Bernstein brought up an idea which I'm not sure 
> > has been brought up in the past.
> 
> Such a feature already exists in SELinux.
> 
> >  I'm not sure whether it's feasible or 
> > not, but at least it (and other methods to limit the functions of a 
> > user-level code) might bear consideration.
> 
> This is precisely what LSM is for, so new security models can be 
> implemented without any direct effect on the core kernel.
> 
> 
> - James
> 

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
