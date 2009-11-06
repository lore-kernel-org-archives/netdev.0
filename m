From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: Using netconsole and getting double prints
Date: Fri, 6 Nov 2009 08:32:40 -0800
Message-ID: <43e72e890911060832k1b831f32w93357c71b370e71c@mail.gmail.com>
References: <43e72e890911051654i19c18bf3nd397662ed79712c4@mail.gmail.com>
	<1257484663.2873.622.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759414AbZKFQc4@vger.kernel.org>
In-Reply-To: <1257484663.2873.622.camel@calx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 5, 2009 at 9:17 PM, Matt Mackall <mpm@selenic.com> wrote:
> On Thu, 2009-11-05 at 16:54 -0800, Luis R. Rodriguez wrote:
>> I'm getting double prints when using netconsole. This used to happen
>> to me and then I just enable debugging log level manually (dmesg -n 8)
>> but now no matter what I try I always get double prints.
>
> This is the first report I've seen of that. Recommend investigating with
> wireshark.

Matt, did you really mean wireshark? I'm a wireless guy so wireshark
to me is this:

http://www.wireshark.org/

The prints have nothing to do with protocols though. I can get a
double print on a simple hello world driver.

  Luis
