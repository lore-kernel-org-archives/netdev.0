From: "David S. Miller" <davem@davemloft.net>
Subject: Re: per-route TCP windows?
Date: Fri, 15 Jul 2005 07:28:46 -0700 (PDT)
Message-ID: <20050715.072846.74728413.davem@davemloft.net>
References: <Pine.LNX.4.44.0507142101310.16602-100000@coffee.psychology.mcmaster.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hahn@physics.mcmaster.ca
In-Reply-To: <Pine.LNX.4.44.0507142101310.16602-100000@coffee.psychology.mcmaster.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Mark Hahn <hahn@physics.mcmaster.ca>
Date: Thu, 14 Jul 2005 21:09:57 -0400 (EDT)

> we'd like to tune for some 10Gb, 3-6 ms links, mainly to move large files
> between our sites.  this is not CERN-scale stuff, but being able to configure
> large windows on particular routes sounds terribly convenient...

You can set the window, but you must lock the setting.
