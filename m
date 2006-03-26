From: jamal <hadi@cyberus.ca>
Subject: Re: [Patch 8/9] generic netlink utility functions
Date: Sun, 26 Mar 2006 12:06:57 -0500
Message-ID: <1143392817.5184.55.camel@jzny2>
References: <1142296834.5858.3.camel@elinux04.optonline.net>
	 <1142297705.5858.28.camel@elinux04.optonline.net>
	 <20060326164434.GC13362@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Shailabh Nagar <nagar@watson.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751191AbWCZRHT@vger.kernel.org>
To: balbir@in.ibm.com
In-Reply-To: <20060326164434.GC13362@in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-26-03 at 22:14 +0530, Balbir Singh wrote:

> Jamal,
> 
> Does the implementation of these utilities look ok? We use genlmsg_data()
> in the delay accounting code but not genlmsg_len(), hence it might not
> be very well tested (just reviewed).
> 

They look fine to me - please resubmit and CC Thomas Graf in case he
sees it different.

cheers,
jamal
