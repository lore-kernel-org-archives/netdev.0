From: Pekka Savola <pekkas@netcore.fi>
Subject: IPv6 ioctl's? [Re: I-D ACTION:draft-ietf-ipngwg-rfc2553bis-07.txt
 - new ioctls? (fwd)]
Date: Fri, 11 Oct 2002 23:33:45 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210112332070.23986-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

What do folks feel -- should there be some ioctl's similar to IPv4 or 
such?

Currently this is basically available through proc or netlink, but I'd 
prefer also to have some (at least almost uniform) mechanisms common to 
most implementations...

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords

---------- Forwarded message ----------
Date: Tue, 8 Oct 2002 11:00:27 -0400
From: Kristine Adamson <adamson@us.ibm.com>
To: ipng@sunroof.eng.sun.com
Subject: Re: I-D ACTION:draft-ietf-ipngwg-rfc2553bis-07.txt - new ioctls?



On 25 Sep 2002 Pekka Savola wrote:

>>This is probably a dumb question, but is there must be a reason why these
>>API's don't talk at all about ioctl's etc?  For example, I see no
standard
>>way of obtaining (all or some) of one's IPv6 addresses, or whatever else
>>was useful with SIOC*.

We also have wondered if there are going to be either IPv6-specific or
version-neutral replacements for the SIOCGIF* ioctls that use an ifreq
structure?  Thanks,

Kristine Adamson
IBM Communications Server for MVS: TCP/IP Development
Internet e-mail:adamson@us.ibm.com

--------------------------------------------------------------------
IETF IPng Working Group Mailing List
IPng Home Page:                      http://playground.sun.com/ipng
FTP archive:                      ftp://playground.sun.com/pub/ipng
Direct all administrative requests to majordomo@sunroof.eng.sun.com
--------------------------------------------------------------------
