From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] IPCONFIG fix and cleanup
Date: Wed, 8 Sep 2004 17:48:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908174800.11adc930.davem@redhat.com>
References: <413FA726.7070006@pantasys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Buckingham <peter@pantasys.com>
In-Reply-To: <413FA726.7070006@pantasys.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 08 Sep 2004 17:43:18 -0700
Peter Buckingham <peter@pantasys.com> wrote:

> The previous fix to DHCPACK missed declaring an iterator variable. based 
> on some comments I modified the patch to look like the below. This will 
> fix the promisicuous DHCPACK problem.

Peter, how are you generating your patches?  They never apply
cleanly.  Maybe Mozilla is messing it up, who knows.  Perhaps
try using attachments instead.
