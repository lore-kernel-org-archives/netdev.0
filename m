From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: Ethernet drivers wiki page
Date: Fri, 4 Jun 2010 15:04:17 -0700
Message-ID: <AANLkTik1isTBolg4IDchOlmKqXOLjQoobZrJ-9bb8ZL5@mail.gmail.com>
References: <AANLkTinSjJsqNvEhJZIE6cJxEkBtg-DO2dqZWMczUy2i@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "H. Peter Anvin" <hpa@kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinSjJsqNvEhJZIE6cJxEkBtg-DO2dqZWMczUy2i@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 4, 2010 at 2:52 PM, Luis R. Rodriguez <mcgrof@gmail.com> wrote:
> Where can I start adding documentation for our Ethernet drivers
> upstream? I was hoping for a wiki but I don't think we have a netdev
> one yet. Shall we create one or piggy back on something else? I'm
> reviewing:
>
> https://wiki.kernel.org/
>
> FWIW, I want to see something like this:
>
> http://wireless.kernel.org/en/users/Drivers
>
> But for ethernet.

Since I've stuffed a few ethernet drivers on compat-wireless I might
as well start carrying more. So now we'd have 802.11, Bluetooth and
Ethernet all backported using the same framework, automatically, down
to at least the oldest stable kernel supported listed on kernel.org
and using all a generic compat module.

I want to document all this crap.

  Luis
