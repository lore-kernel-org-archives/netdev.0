From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 on-link assumption considered harmful
Date: Mon, 3 Nov 2003 09:26:36 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311030922500.27508-100000@netcore.fi>
References: <1067615762.3423.264.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1067615762.3423.264.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 31 Oct 2003, David Woodhouse wrote:
> On Thu, 2003-10-30 at 21:09 +0200, Pekka Savola wrote:
> > Just to give a heads-up before this is finalized, to give people ability 
> > to prepare or comment prior to this process is formalized in the IETF.
> 
> With corresponding changes to the route advertisement protocol as used
> by radvd, so that routes can actually be advertised to autoconfigured
> nodes? Or does that already exist and I just missed it when I was
> looking?

Do you mean:

http://www.ietf.org/internet-drafts/draft-ietf-ipv6-router-selection-02.txt

This has nothing to do with this subject (AFAICS), but one person just a 
couple of days ago asked about this and wanted to know whether anyone else 
is hacking this, and if not, whether he should go ahead.  We gave (as 
radvd maintainers) a thumbs-up.

If you're also interested in hacking this, contact me off-list, and I'll 
ask the other person whether he'd like to get some help..

(Obviously, the preferences will need support in the kernel too.)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
