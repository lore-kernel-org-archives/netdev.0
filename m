From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: ?completeness of IPsec feature-set
Date: Fri, 28 Mar 2003 08:32:48 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0303280827570.25478-100000@netcore.fi>
References: <20030327215839.GA31029@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "John S. Denker" <jsd@monmouth.com>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20030327215839.GA31029@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Mar 2003, bert hubert wrote:
> > I ask again:  Is there a document somewhere listing the set of desirable
> > features and the status thereof?  Or otherwise is there something to
> > reassure would-be users that a complete feature-set will be provided?
> 
> Right now, the kernel side of things is nearly complete. I sorely miss IPSEC
> NAT traversal which appears to be pretty patented.

Note that at least some IPR-claimants have decreed IPsec NAT-traversal a 
roualty free technology in interests to promote its use, see 
http://www.ietf.org/ipr

It seems SSH and ipunplugged offer RF terms (to the extent of implementing
the IETF standards track implementation, which it isn't at the moment)
while Microsoft and Cisco don't.

I'm particularly interested if this is considered to be a problem.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
