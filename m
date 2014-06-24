From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: SmPL for automatic request_firmware_nowait() conversion
Date: Tue, 24 Jun 2014 15:06:47 -0700
Message-ID: <CAB=NE6Xz6V20fQfMq8HtmdA2ATUpFnOyLHK5W+OvLCj9Ce9+Vg@mail.gmail.com>
References: <20140621015714.GX4841@wotan.suse.de> <20140621105205.GA31611@electric-eye.fr.zoreil.com>
 <20140623232107.GB27687@wotan.suse.de> <20140624215828.GA14124@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: cocci@systeme.lip6.fr,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140624215828.GA14124@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 24, 2014 at 2:58 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Thanks for the pointers.
>
> I can't help thinking that there's a bit of sensationalism in the
> timeout * num CPUs argument though. :o)

Indeed, this actually only applies to microcode which will end up
using the API for each CPU it seems.

  Luis
