From: "David S. Miller" <davem@redhat.com>
Subject: Re: netdev_ops?
Date: Tue, 22 Jul 2003 23:02:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030722230215.284dd270.davem@redhat.com>
References: <3F1E17BC.30100@candelatech.com>
	<20030722220745.379a73c6.davem@redhat.com>
	<3F1E1D62.90009@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F1E1D62.90009@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jul 2003 22:30:10 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Any interest in a lower-risk netdev-ops lite?

Not really.

Nobody is really helped with this, not even you.  It makes almost no
sense to make a driver only work with a 2.4.x kernel that has this
netdev-ops-lite thing patched into it, because then it doesn't work on
all the bazillion other 2.4.x kernels out there.
