From: "David S. Miller" <davem@redhat.com>
Subject: Re: VLAN patch try 2, tabs instead of spaces
Date: Sat, 30 Aug 2003 22:34:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030830223419.3a9ee2b4.davem@redhat.com>
References: <3F3080C4.9070507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F3080C4.9070507@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 05 Aug 2003 21:15:00 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Same as last time, but now using tabs instead of spaces.

I was about to apply this, then I noticed that you
whitespace fixed the entire file.

Please don't do that, I want just your change not your
change + whitespace cleanups.  That makes it hard to
figure out exactly what your patch actually does amongst
all the whitespace changes.
