From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Performance bottleneck with ndo_start_xmit
Date: Tue, 7 Jul 2015 20:14:42 +0200
Message-ID: <CAHmME9qzeMBPbxJug9FWCNW2iZ1CpkOcM_UGeECB7MAur0-KKw@mail.gmail.com>
References: <CAHmME9rfOqA1mYmFDomcG+G55dV7it5406vL02ZRWcr0PmVbQg@mail.gmail.com>
	<20150707111031.4ebabd36@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150707111031.4ebabd36@urahara>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 7, 2015 at 8:10 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Is it open source, is the source available to look at?
> If not, please solve your own problems.

Yes it is. Right now the repo is under password because it's supposed
to keep your data secure, but I haven't audited it yet, and I don't
want someone to rely on the software erroneously before I've made sure
it's safe. If my general question here doesn't turn up any good
pointers, I'll take the password off the repo and just add some
massive "do not use!" warnings.
