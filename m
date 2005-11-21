From: "Christopher Friesen" <cfriesen@nortel.com>
Subject: netlink nlmsg_pid supposed to be pid or tid?
Date: Mon, 21 Nov 2005 13:32:19 -0600
Message-ID: <438220C3.4040602@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932187AbVKUTcf@vger.kernel.org>
To: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When using netlink, should "nlmsg_pid" be set to pid (current->tgid) or 
tid (current->pid)?

Chris
