From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC v2 1/2] PCI-Express Non-Transparent Bridge Support
Date: Tue, 31 Jul 2012 15:23:38 -0700
Message-ID: <20120731222338.GA19134@kroah.com>
References: <1343607994-32415-1-git-send-email-jon.mason@intel.com>
 <1343607994-32415-2-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1343607994-32415-2-git-send-email-jon.mason@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 29, 2012 at 05:26:33PM -0700, Jon Mason wrote:
> + *   You should have received a copy of the GNU General Public License
> + *   along with this program; if not, write to the Free Software
> + *   Foundation, Inc., 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.

You really are going to track the FSF's office movements for the next
40+ years?

> + *   The full GNU General Public License is included in this distribution
> + *   in the file called LICENSE.GPL.

No it isn't, this sentance is totally wrong for any in-kernel code,
please remove it.

Also do the same for all the other files you added please.

greg k-h
