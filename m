From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: kernel crash with G5 Xserve and sungem driver
Date: Fri, 01 Oct 2004 13:42:44 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415DB334.4010809@nortelnetworks.com>
References: <415D8768.8080808@nortelnetworks.com> <20041001193153.GN27499@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linuxppc-dev@ozlabs.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20041001193153.GN27499@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald Welte wrote:

> Just don't compile (or load) the sungem driver on those boxes.

Hmm.  That's a pain.  We've got G5 desktops too, and it would be nice to be able 
to run one kernel for both.  It'd be better (IMHO) to fix the driver so it 
doesn't crash.

Chris
