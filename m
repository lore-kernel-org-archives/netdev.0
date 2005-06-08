From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 7 Jun 2005 18:50:44 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0506071848480.31708@ladlxr>
References: <468F3FDA28AA87429AD807992E22D07E0450C00B@orsmsx408>
 <Pine.CYG.4.58.0506061647340.128@mawilli1-desk2.amr.corp.intel.com>
 <42A4E599.2090604@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Ronciak, John" <john.ronciak@intel.com>,
        "David S. Miller" <davem@davemloft.net>, mchan@broadcom.com,
        hadi@cyberus.ca, buytenh@wantstofly.org, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <42A4E599.2090604@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 6 Jun 2005, Ben Greear wrote:

> So is the Linux server reading/writing these large files to/from the
> disk?

no, the test runs completely from memory, and the clients are 
reading/writing from/to the server

> Can you tell us how much performance went down when you increased the
> descriptors to 512?

sorry don't know the answer to that one.
