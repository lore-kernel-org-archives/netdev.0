From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 1 Apr 2009 23:00:24 -0700
Message-ID: <20090402060024.GY18394@sequoia.sous-sol.org>
References: <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <20090401204039.GR18394@sequoia.sous-sol.org> <49D3D88E.3090009@novell.com> <20090401212830.GT18394@sequoia.sous-sol.org> <49D3E649.7000906@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D3E649.7000906@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Gregory Haskins (ghaskins@novell.com) wrote:

<snip nice list>

> I cant think of more examples right now, but I will update this list
> if/when I come up with more.  I hope that satisfactorily answered your
> question, though!

Yes, that helps, thanks.

There's still the simple issue of guest/host interface widening w/ kernel
resident backend where a plain ol' bug (good that you thought about the
isolation) can take out more than single guest.  Always the balance... ;-)
