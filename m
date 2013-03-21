From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: Re: [BUG NFQUEUE] NFQUEUE readers get -PERM from sys_sendto() if
 !root
Date: Thu, 21 Mar 2013 16:19:45 +0100
Message-ID: <20130321151945.GI13505@imap.eitzenberger.org>
References: <20130321143643.GH13505@imap.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130321143643.GH13505@imap.eitzenberger.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Turns out that this is some broken interaction with some
internal patches.  Sorry for the noise.

 /Holger

