From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 13:31:32 +0200
Message-ID: <20050622113132.GR14251@wotan.suse.de>
References: <Pine.LNX.4.44.0506211642290.21812-100000@bluewest.scyld.com> <42B8ECA0.5060904@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Donald Becker <becker@scyld.com>, Andi Kleen <ak@suse.de>,
        Rick Jones <rick.jones2@hp.com>, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortel.com>
Content-Disposition: inline
In-Reply-To: <42B8ECA0.5060904@nortel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> If I recall, G4 chips are 32 bytes, and G5s are 128 bytes.  Most current 
> x86 chips are 64 bytes though.

P4s are effectively 128 byte. And that is the most common x86 right now.

-Andi
