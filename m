From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: NetKGDB v3
Date: Mon, 27 Feb 2012 16:04:50 -0800
Message-ID: <20120227160450.022784bb@nehalam.linuxnetplumber.net>
References: <1330137851-4716-1-git-send-email-andrey.warkentin@gmail.com>
	<1330313411-845-1-git-send-email-andrey.warkentin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrei Warkentin <andrey.warkentin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330313411-845-1-git-send-email-andrey.warkentin@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 26 Feb 2012 22:30:08 -0500
Andrei Warkentin <andrey.warkentin@gmail.com> wrote:

> netkgdb is designed to accept connections
> from any hosts, i.e. it is not necessary to specify these ahead
> of time. This makes it that much more useful in a "this host crashed
> and a I want a developer to take a look at it" scenario, common to
> large scale test/QA farms and automated testing harnesses.

And opens a security hole so wide that no production network
or distro should ever enable it!
