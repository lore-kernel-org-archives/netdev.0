From: "David S. Miller" <davem@redhat.com>
Subject: Re: MLD problems (again) [PATCH]
Date: Tue, 13 Jan 2004 16:15:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113161515.0bff155e.davem@redhat.com>
References: <OF5F20AEAF.88A82C91-ON88256E19.001F1E69@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hibi665@oki.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF5F20AEAF.88A82C91-ON88256E19.001F1E69@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 11 Jan 2004 22:49:08 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

>       Although IGMPv3 didn't have any problems, this patch
> also re-arranges the order of the filter changes. I think it's cleaner
> to add the new one first and then delete the old one, rather than
> having a small window with no filter set. So, this is a bug fix for MLD
> and a code clean-up for IGMPv3.
>       This bug and patch should also apply to the 2.4 line.

Applied, thank you David.

Also, arigato Takashi-san for the bug report and testing.
