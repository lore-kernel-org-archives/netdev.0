From: Andi Kleen <ak@suse.de>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 21:52:44 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210215244.4713fd25.ak@suse.de>
References: <20031210203433.3747b7fd.ak@suse.de>
	<Pine.LNX.4.44.0312101218280.1354-100000@w-kevinr.svc.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Kevin W. Rudd" <ruddk@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0312101218280.1354-100000@w-kevinr.svc.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Dec 2003 12:26:26 -0800 (PST)
"Kevin W. Rudd" <ruddk@us.ibm.com> wrote:

> I don't think it's practical to make these types of changes at the
> router level.  

Just changing all end hosts for this will be likely even less practical
because there are much more of them than routers.

-Andi
