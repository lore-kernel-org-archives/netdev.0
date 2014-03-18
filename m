From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH 0/3] bridge: few enhancements and small fixes
Date: Tue, 18 Mar 2014 13:31:19 -0700
Message-ID: <CAB=NE6W4pSyCU+zFKQPVFoQy5s8KGx34nEepRS0MnhnJuwf0Mg@mail.gmail.com>
References: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kvm@vger.kernel.org, xen-devel@lists.xenproject.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 8:15 PM, Luis R. Rodriguez
<mcgrof@do-not-panic.com> wrote:
> Here's a few fixes I've been carrying around. I've now tested them
> on as many systems / environments as I can. They should be ready.
>
> Luis R. Rodriguez (3):
>   bridge: preserve random init MAC address
>   bridge: trigger a bridge calculation upon port changes
>   bridge: fix bridge root block on designated port

Folks, let me know if there are any other questions or if you spot any
other possible issues.

  Luis
