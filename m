From: "David S. Miller" <davem@redhat.com>
Subject: Re: netdev_ops?
Date: Tue, 22 Jul 2003 22:07:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030722220745.379a73c6.davem@redhat.com>
References: <3F1E17BC.30100@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F1E17BC.30100@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jul 2003 22:06:04 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Any progress towards getting the netdev_ops into 2.4?
> 
> I have several patches that would benefit (in that no new ioctls
> would be needed) if this goes in.

If anything, it's going to go into 2.6.x first, and then backported
to 2.4.x after it's had a few months of testing and tweaking.
